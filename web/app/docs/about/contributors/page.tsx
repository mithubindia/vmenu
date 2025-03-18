import { Users, FlaskRound } from 'lucide-react';

const contributors = [
  {
    name: 'MALOW',
    role: 'Testing',
    avatar: 'https://macrimi.github.io/ProxMenux/avatars/malow.png'
  },
  {
    name: 'Segarra',
    role: 'Testing',
    avatar: 'https://macrimi.github.io/ProxMenux/avatars/segarra.png'
  },
  {
    name: 'Aprilia',
    role: 'Testing',
    avatar: 'https://macrimi.github.io/ProxMenux/avatars/aprilia.png'
  }
];

export default function Contributors() {
  return (
    <div className="container mx-auto px-4 py-8">
      {/* 🔹 Icon + Title */}
      <div className="flex items-center justify-center mb-6">
        <Users className="h-8 w-8 mr-2 text-blue-500" />
        <h1 className="text-3xl font-bold text-black">Contributors</h1>
      </div>

      {/* 🔹 Description */}
      <p className="text-lg text-black mb-4 text-left">
        The ProxMenux project grows and thrives thanks to the contribution of its collaborators.
      </p>
      <p className="text-base text-black mb-20">
        This is the well-deserved recognition of their work:
      </p>

      {/* 🔹 Contributors List */}
      <div className="flex justify-center gap-6 flex-wrap">
        {contributors.map((contributor) => (
          <div key={contributor.name} className="text-center">
            <div className="relative inline-block">
              <img
                src={contributor.avatar}
                alt={contributor.name}
                className="w-20 h-20 rounded-full border-2 border-gray-300 object-cover"
              />
              <div className="absolute -bottom-1 -right-1 bg-orange-500 rounded-full p-1">
                <FlaskRound className="h-4 w-4 text-white" />
              </div>
            </div>
            <h3 className="text-lg font-bold text-black mt-2">{contributor.name}</h3>
            <p className="text-sm text-black">{contributor.role}</p>
          </div>
        ))}
      </div>

      {/* 🔹 Call to Action */}
      <p className="mt-20 text-base text-black text-left">
        Would you like to contribute? You can collaborate as a <strong>tester</strong>, <strong>developer</strong>, <strong>designer</strong>, or by sharing <strong>ideas and suggestions</strong>. Any contribution is welcome!
      </p>
    </div>
  );
}

